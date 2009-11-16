From: David Miller <davem@davemloft.net>
Subject: Re: [RFC-PATCH] libiscsi dhcp handler
Date: Mon, 16 Nov 2009 05:18:35 -0800 (PST)
Message-ID: <20091116.051835.125328285.davem@davemloft.net>
References: <4B014F95.8000906@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	James.Bottomley@suse.de, kxie@chelsio.com
To: rakesh@chelsio.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753011AbZKPNSU@vger.kernel.org>
In-Reply-To: <4B014F95.8000906@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rakesh Ranjan <rakesh@chelsio.com>
Date: Mon, 16 Nov 2009 18:41:49 +0530

> Herein attached patches to support dhcp based provisioning for iSCSI
> offload capable cards. I have made dhcp code as generic as possible,
> please go through the code. Based on the feedback I will submit final
> version of these patches.

You can't really add objects to the build before the patch that
adds the source for that object.
