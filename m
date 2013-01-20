From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 17:07:22 -0500
Message-ID: <20130120220721.GA5434@home.goodmis.org>
References: <20130120103132.GA16800@pd.tnic>
 <313650836.93071.1358686587647.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Borislav Petkov <bp@alien8.de>, Eric Dumazet <erdnetdev@gmail.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
	Mike Galbraith <bitbucket@online.de>
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <313650836.93071.1358686587647.JavaMail.root@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 20, 2013 at 07:56:27AM -0500, Tom St Denis wrote:
> 
> You should really try running checkpatch.pl over code that's already in the kernel before you call out new contributors on it.
> 
> How is this supposed to not be adversarial when I can't even use the Kernel source itself as a reference?

So there's a lot of crap code in the kernel (that we are trying to clean
up when we have the time... see Kernel Janitors). But that's still no
excuse to allow more crap code to enter. That means adding more crap to
clean up.

-- Steve
