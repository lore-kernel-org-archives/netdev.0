From: cranium2003 <cranium2003@yahoo.com>
Subject: Re: how netfilter handles fragmented packets
Date: Sun, 21 Nov 2004 11:42:02 -0800 (PST)
Message-ID: <20041121194202.14581.qmail@web41407.mail.yahoo.com>
References: <29495f1d04112109372bb8ebe4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernelnewbies@nl.linux.org, linux-kernel@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261801AbUKUTmI@vger.kernel.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
In-Reply-To: <29495f1d04112109372bb8ebe4@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Nish Aravamudan <nish.aravamudan@gmail.com> wrote:
Hello Nish,

> On Sun, 21 Nov 2004 17:15:12 +0100 (MET), Jan
> Engelhardt
> <jengelh@linux01.gwdg.de> wrote:
> > >hello,
> > >          In ip_output.c file ip_fragmet function
> when
> > >create a new fragmented packet given to
> output(skb)
> > >function. i want to know which function are
> actually
> > >called by output(skb)?
> > 
> > use stack_dump() (or was it dump_stack()?)
> 
> dump_stack(), if you want to dump the current
> process' stack context.
> 
> -Nish
> 

can you please tell me how can i use dump_stack()
method? so using dump_stack i will come to know which
function will be called by output(skb) right? But
where i get dump_stack()???
regards,
cranium


		
__________________________________ 
Do you Yahoo!? 
Meet the all-new My Yahoo! - Try it today! 
http://my.yahoo.com 
 
