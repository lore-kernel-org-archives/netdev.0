From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Consolidate multiple implementations of jiffies-msecs
 conversions.
Date: Thu, 25 Mar 2004 15:36:42 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <406342DA.30901@pobox.com>
References: <Pine.LNX.4.58.0403251142110.3037@localhost.localdomain> <20040325123206.00b2dd1a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040325123206.00b2dd1a.davem@redhat.com>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 25 Mar 2004 12:17:41 -0800 (PST)
> Sridhar Samudrala <sri@us.ibm.com> wrote:
> 
> 
>>The following patch to 2.6.5-rc2 consolidates 6 different implementations
>>of msecs to jiffies and 3 different implementation of jiffies to msecs.
>>All of them now use the generic msecs_to_jiffies() and jiffies_to_msecs()
>>that are added to include/linux/time.h
> 
> 
> This looks fine to me.
> 
> Jeff, I'll merge this upstream.


Nod, looks good here too.

	Jeff
