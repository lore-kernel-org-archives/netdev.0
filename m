From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/10] cxgb3: Chelsio T3 1G/10G ethernet device driver
Date: Fri, 17 Nov 2006 12:22:20 -0800
Message-ID: <455E19FC.7060505@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755867AbWKQUZR@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Based on Arnd's feedback, I re-submit the patch supporting the latest
Chelsio T3 adapter in inlined mails.  Some header files were trimmed
down to reduce the code footprint.

This patch adds support for the latest Chelsio adapter, T3.  It is built
against 2.6.19-rc6.

A corresponding monolithic patch against 2.6.19-rc6 is posted at the
following URL: http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

We wish this patch to be considered for inclusion in 2.6.20. This driver
is required by the Chelsio T3 RDMA driver which was posted on 11/15/2006.

Cheers,
Divy
