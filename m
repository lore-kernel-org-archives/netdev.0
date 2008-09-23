From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Machine Check Exception Re: NetDev! Please help!
Date: Tue, 23 Sep 2008 11:43:08 +0400
Message-ID: <48D89E0C.9040407@bigtelecom.ru>
References: <48D4F85C.8090709@bigtelecom.ru> <200809202111.01256.denys@visp.net.lb> <48D67239.9040006@gmail.com> <48D7385D.40107@bigtelecom.ru> <20080922065339.GA4399@ff.dom.local> <48D76813.9000603@bigtelecom.ru> <20080922112452.GB5314@ff.dom.local> <48D79709.80400@bigtelecom.ru> <20080922172349.GA2545@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754281AbYIWHnZ@vger.kernel.org>
In-Reply-To: <20080922172349.GA2545@ami.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

I stop eth1 and eth0 and run "emegre portage" and get exception. Now i
think its not problem in network part.

I miss situation in 2.6.27 about multiqueue and traffic shaper because i
was have many work and was can't read all netdev list =(
As i understand 2.6.27-rc have support multiqueue, but how it will work
with HTB/SFQ?
Is tc rules must have in 2.6.27 one root queue (and all queue go to this
tree) or need to do many qdiscs and settings it to device queues (i was
read some about queue2band)?
If it is simple for you - can  you sort describe this part of changes?

P.S. I think now that problem not in network part of kernel and i think
i stop CC netdev and Denys Fedoryshchenko. Thanks for you doing and
thanks for help!

Thanks.

> Actually, it's quite well tested, especially by Denys, and I doubt it
> will be much better in 2.6.27. BTW, maybe start eth1, stop eth0 yet?
>
> Thanks,
> Jarek P.
>
>   
