From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: ADSL/ATM linklayer tc shaping regression fix commits for stable
Date: Thu, 22 Aug 2013 10:41:48 +0200
Message-ID: <20130822104148.7e533422@redhat.com>
References: <20130821140350.2b953007@redhat.com>
	<20130821.112023.744177612387539958.davem@davemloft.net>
	<20130822100426.39be319d@redhat.com>
	<20130822.012348.1370012681436362922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, gregkh@linuxfoundation.org,
	stable@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130822.012348.1370012681436362922.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Aug 2013 01:23:48 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Thu, 22 Aug 2013 10:04:26 +0200
> 
> > So, for future reference:
> > 
> > Stable patches for the networking tree, I should:
> > 1) check http://patchwork.ozlabs.org/bundle/davem/stable/?state=*
> >    to see if my patch is already on your stable queue
> > 2) if not, ask you and cc netdev@vger.kernel.org
> > 3) you will handle the interaction with Greg and stable@vger.kernel.org
> > 
> > Correct?
> 
> Yes, and that's how it's been with the networking for years.

Yes, and in the future, documentation of this will be available here:
 Documentation/networking/netdev-FAQ.txt

Right now is only available via net-next:
 https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/Documentation/networking/netdev-FAQ.txt
or
 https://lwn.net/Articles/559211/

Guess, we should add a pointer to this new doc from
Documentation/stable_kernel_rules.txt once it hits Linus'es tree.

Now I cannot find any more ways to spell-it-out, for people searching google ;-)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
