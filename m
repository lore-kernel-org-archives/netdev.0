From: "Krishna Kumar" <kumarkr@us.ibm.com>
Subject: Re: Neighbor cache
Date: Thu, 2 May 2002 17:07:20 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <OF8105B87F.1724625E-ON88256BAE.00007CE3@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, owner-netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "Xiaoning He" <xiaoning@docomolabs-usa.com>
List-Id: netdev.vger.kernel.org


Look for "struct neighbour" and "struct neigh_table" in neighbour.h and
it's usage. Functions are  neigh_lookup(), neigh_create(), neigh_destroy(),
etc.

- KK



                                                                                                                                              
                      "Xiaoning He"                                                                                                           
                      <xiaoning@docomola        To:       <netdev@oss.sgi.com>                                                                
                      bs-usa.com>               cc:                                                                                           
                      Sent by:                  Subject:  Neighbor cache                                                                      
                      owner-netdev@oss.s                                                                                                      
                      gi.com                                                                                                                  
                                                                                                                                              
                                                                                                                                              
                      05/02/2002 03:54                                                                                                        
                      PM                                                                                                                      
                                                                                                                                              
                                                                                                                                              



Hi All

I have a question related to the Neighbor cache. I am currently trying
to modify the neighbor cache but I can not find where the code in the
IPv6 kernel.

Could you please let me know in the IPv6 kernel, where the Neighbor
cache is maintained and which file contains them?

Thank you very much.

Xiaoning He
