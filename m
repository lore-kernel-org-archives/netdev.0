From: "Kanna" <kanna@jcastnet.com>
Subject: Re: netfilter query
Date: Wed, 17 Nov 2004 14:06:59 +0530
Message-ID: <007001c4cc80$9e960ad0$3418fe0a@jcastindia.com>
References: <20041117065941.27060.qmail@webmail26.rediffmail.com>
Reply-To: Kanna <kanna@jcastnet.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "bunty" <bunty123_4@rediffmail.com>, <kernelnewbies@nl.linux.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

The below link may help you to create your own firewall module for linux
kernel........    Sample program also available on below url Link .

http://www.linuxjournal.com/article/7184




----- Original Message ----- 
From: "bunty " <bunty123_4@rediffmail.com>
To: <kernelnewbies@nl.linux.org>
Cc: <netdev@oss.sgi.com>; <netfilter-devel@lists.netfilter.org>
Sent: Wednesday, November 17, 2004 12:29 PM
Subject: netfilter query


  hello,

    if I want to insert an extra overhead in packets destined for routers
how a netfilters can help me?  can netfilter allow to increase the allocated
space to packets at NF_IP_LOCAL_OUT?

    How a netfilter help to write a module that call my own routine. can
anybody provide a sample program that calls user routine at netfilter hooks?

regards,
parag.
