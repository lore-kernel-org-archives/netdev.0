From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH net-next] Documentation: add networking/netdev-FAQ.txt
Date: Sun, 04 Aug 2013 21:34:11 -0500
Message-ID: <1375670051.8422.6@driftwood>
References: <1375298180-17628-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1375298180-17628-1-git-send-email-paul.gortmaker@windriver.com>
	(from paul.gortmaker@windriver.com on Wed Jul 31 14:16:20 2013)
Content-Disposition: inline
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/31/2013 02:16:20 PM, Paul Gortmaker wrote:
> A collection of expectations and operational details about how
> networking development takes place in the context of the netdev
> mailing list.

http://vger.kernel.org has 149 mailing lists, and that's maybe half of  
the kernel lists out there. (The linux foundation's got a bunch, the  
device tree list just switched servers, etc.)

Why is this list special?

> +++ b/Documentation/networking/netdev-FAQ.txt
> @@ -0,0 +1,224 @@
> +
> +Information you need to know about netdev
> +-----------------------------------------
> +
> +Q: What is netdev?
> +
> +A: It is a mailing list for all network related linux stuff.  This  
> includes
> +   anything found under net/  (i.e. core code like IPv6) and  
> drivers/net
> +   (i.e. hardware specific drivers) in the linux source tree.

I'm all for having this somewhere, but this is a silly place for it.

Putting it in linux/Documentation means you'll frequently tell newbies  
"read the FAQ, except it's not on the web, we stuck it in a  
subdirectory of a sudirectory of the kernel source because that's the  
obvious place to stick the FAQ for a mailing list".

Rob