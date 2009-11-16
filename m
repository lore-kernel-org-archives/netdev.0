From: Rakesh Ranjan <rakesh@chelsio.com>
Subject: Re: [RFC-PATCH] libiscsi dhcp handler
Date: Mon, 16 Nov 2009 18:54:42 +0530
Message-ID: <4B01529A.80900@chelsio.com>
References: <4B014F95.8000906@chelsio.com> <20091116.051835.125328285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	James.Bottomley@suse.de, kxie@chelsio.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753199AbZKPNYy@vger.kernel.org>
In-Reply-To: <20091116.051835.125328285.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rakesh Ranjan <rakesh@chelsio.com>
> Date: Mon, 16 Nov 2009 18:41:49 +0530
> 
>> Herein attached patches to support dhcp based provisioning for iSCSI
>> offload capable cards. I have made dhcp code as generic as possible,
>> please go through the code. Based on the feedback I will submit final
>> version of these patches.
> 
> You can't really add objects to the build before the patch that
> adds the source for that object.
> 

my mistake, the makefile part of patch is irrelevant. Will send new
patch in few mins.

Regards
Rakesh Ranjan
