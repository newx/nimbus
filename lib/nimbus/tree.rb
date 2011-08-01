module Nimbus
  
  class Tree
    attr_accessor :snp_sample_size, :snp_total_count, :node_min_size, :max_branches, :structure
    attr_accessor :individuals, :id_to_fenotype
    
    def initialize(options)
      @snp_total_count = options[:snp_total_count]
      @snp_sample_size = options[:snp_sample_size]
      @node_min_size = options[:tree_node_min_size]
      @max_branches = options[:tree_max_branches]
    end
    
    def seed(all_individuals, individuals_sample, ids_fenotypes)
      @individuals = all_individuals
      @id_to_fenotype = ids_fenotypes
      
      @structure = build_node individuals_sample, Nimbus::LossFunctions.average(individuals_sample, @id_to_fenotype)
    end

    def build_node(individuals_ids, y_hat)
      # General loss function value for the node
      individuals_count = individuals_ids.size
      return y_hat.round(5) if individuals_count < @node_min_size
      node_loss_function = Nimbus::LossFunctions.quadratic_loss individuals_ids, @id_to_fenotype, y_hat
      
      # Finding the SNP that minimizes loss function
      snps = snps_random_sample
      min_loss, min_SNP, split, means  = node_loss_function, nil, nil, nil

      snps.each do |snp|
        individuals_split_by_snp_value = split_by_snp_value individuals_ids, snp
        mean_0 = Nimbus::LossFunctions.average individuals_split_by_snp_value[0], @id_to_fenotype
        mean_1 = Nimbus::LossFunctions.average individuals_split_by_snp_value[1], @id_to_fenotype
        mean_2 = Nimbus::LossFunctions.average individuals_split_by_snp_value[2], @id_to_fenotype
        loss_0 = Nimbus::LossFunctions.mean_squared_error individuals_split_by_snp_value[0], @id_to_fenotype, mean_0
        loss_1 = Nimbus::LossFunctions.mean_squared_error individuals_split_by_snp_value[1], @id_to_fenotype, mean_1
        loss_2 = Nimbus::LossFunctions.mean_squared_error individuals_split_by_snp_value[2], @id_to_fenotype, mean_2
        loss_snp = (loss_0 + loss_1 + loss_2) / individuals_count
        
        min_loss, min_SNP, split, means = loss_snp, snp, individuals_split_by_snp_value, [mean_0, mean_1, mean_2] if loss_snp < min_loss
      end
      
      
      return build_branch(min_SNP, split, means, y_hat) if min_loss < node_loss_function
      return y_hat.round(5)
    end
    
    def build_branch(snp, split, y_hats, parent_y_hat)
      node_0 = split[0].size == 0 ? parent_y_hat.round(5) : build_node(split[0], y_hats[0])
      node_1 = split[1].size == 0 ? parent_y_hat.round(5) : build_node(split[1], y_hats[1])
      node_2 = split[2].size == 0 ? parent_y_hat.round(5) : build_node(split[2], y_hats[2])
      
      return { snp => [node_0, node_1, node_2] }
    end
    
    def traverse
      
    end
    
    def self.traverse(structure, data)
      
    end
    
    
    private
    
    def snps_random_sample
      (1..@snp_total_count).to_a.sample(@snp_sample_size).sort
    end
    
    def split_by_snp_value(ids, snp)
      split = [[], [], []]
      ids.each do |i|
        split[ @individuals[i].snp_list[snp-1] ] << @individuals[i].id
      end
      split
    rescue => ex
      raise Nimbus::TreeError, "Values for SNPs columns must be in [0, 1, 2]"
    end
    
  end
  
end