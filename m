From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: TCP rto estimation patch
Date: Fri, 23 Apr 2004 14:06:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFE28EC49F.335C9D5D-ON88256E7F.0073BC2E-88256E7F.0073F700@us.ibm.com>
References: <20040423142445.GC501@grc.nasa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040423142445.GC501@grc.nasa.gov>
To: weddy@grc.nasa.gov
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I believe "2" and "3" are the scale factors for the fixed-point 
representation
of the data, not the "alpha" and "beta" I remember from the estimator 
paper.

                                +-DLS
