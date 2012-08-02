From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] firmware: Remove obsolete Chelsio cxgb3 firmware
Date: Thu, 02 Aug 2012 00:20:00 -0700 (PDT)
Message-ID: <20120802.002000.2023014747210925552.davem@davemloft.net>
References: <1343848670-31504-1-git-send-email-tim.gardner@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	ben@decadent.org.uk, JBottomley@Parallels.com,
	dan.j.williams@intel.com, divy@chelsio.com, netdev@vger.kernel.org
To: tim.gardner@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343848670-31504-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Gardner <tim.gardner@canonical.com>
Date: Wed,  1 Aug 2012 13:17:50 -0600

> The current firmware version used by the device driver
> is 7.12.0
> 
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> Cc: Ben Hutchings <ben@decadent.org.uk>
> Cc: James Bottomley <JBottomley@Parallels.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Divy Le Ray <divy@chelsio.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>

"git am" refuses to apply this to current 'net':

Applying: firmware: Remove obsolete Chelsio cxgb3 firmware
error: removal patch leaves file contents
error: firmware/cxgb3/t3fw-7.10.0.bin.ihex: patch does not apply
