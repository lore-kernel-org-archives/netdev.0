From: "David S. Miller" <davem@redhat.com>
Subject: Re: TCP rto estimation patch
Date: Fri, 23 Apr 2004 14:09:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040423140913.5a7491b9.davem@redhat.com>
References: <20040423142445.GC501@grc.nasa.gov>
	<OFE28EC49F.335C9D5D-ON88256E7F.0073BC2E-88256E7F.0073F700@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: weddy@grc.nasa.gov, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFE28EC49F.335C9D5D-ON88256E7F.0073BC2E-88256E7F.0073F700@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 23 Apr 2004 14:06:39 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> I believe "2" and "3" are the scale factors for the fixed-point 
> representation
> of the data, not the "alpha" and "beta" I remember from the estimator 
> paper.

That's correct.
