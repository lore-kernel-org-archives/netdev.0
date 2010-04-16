From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: another cleanup patch gone wrong
Date: Fri, 16 Apr 2010 13:21:52 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1004161318470.271@localhost>
References: <alpine.OSX.2.00.1004161214270.271@localhost> <1271387506.2298.17.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <p_gortmaker@yahoo.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux/m68k <linux-m68k@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1271387506.2298.17.camel@Joe-Laptop.home>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 15 Apr 2010, Joe Perches wrote:

> > Why the macro? You only used it once.
> 
> It's used embedded in the pr_<level> functions.
> It's used more than once.
> 
> > The pr_xxx naming convention belongs to a kernel-wide include file. Is it 
> > really a good idea to start repurposing it in .c files?
> 
> It's in kernel.h, and yes, it is.
> http://lkml.org/lkml/2008/11/12/297

My mistake.

Finn
