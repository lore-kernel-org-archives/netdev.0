From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 data corruption (TSO ?)
Date: Fri, 08 Sep 2006 15:07:22 -0700
Message-ID: <1157753242.9584.4.camel@rh4>
References: <1551EAE59135BE47B544934E30FC4FC093FB19@NT-IRVA-0751.brcm.ad.broadcom.com>
 <1157751689.31071.97.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Segher Boessenkool" <segher@kernel.crashing.org>,
	"Linux Kernel list" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751219AbWIHWJW@vger.kernel.org>
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>
In-Reply-To: <1157751689.31071.97.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-09-09 at 07:41 +1000, Benjamin Herrenschmidt wrote:

> As for the tcpdump output, well, I have a 3Gb file for now :) I need to do a bit of surgery on it to
> get only the interesting part. I'll try to do that later today (but it may have to wait for monday).
> 
Ben, We probably don't need the tcpdump anymore now that we know it's a
memory ordering issue.
