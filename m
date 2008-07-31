From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] PCI: Limit VPD length for Broadcom 5708S
Date: Thu, 31 Jul 2008 12:39:28 -0700
Message-ID: <200807311239.28769.jbarnes@virtuousgeek.org>
References: <48920413.6080508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com, willy@linux.intel.com,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758159AbYGaTjq@vger.kernel.org>
In-Reply-To: <48920413.6080508@cosmosbay.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, July 31, 2008 11:27 am Eric Dumazet wrote:
> While trying to upgrade kernel from 2.6.25 to 2.6.26 on a ProLiant BL460c
> G1, I faced this problem on integrated Broadcom 5708S NIC when trying to UP
> them.

Thanks Eric, I applied this to my for-linus branch.  I'll bounce the original 
over to stable@.

Jesse
