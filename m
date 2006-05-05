From: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Subject: too many iterations (6) in nv_nic_irq
Date: Fri, 05 May 2006 12:02:50 +0200
Message-ID: <445B22CA.4050405@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <AAbdulla@nvidia.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:61391 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1030349AbWEEKCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 06:02:53 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

IIRC you had "too many iterations (6) in nv_nic_irq" appear regularly
in your dmesg with kernel 2.6.16. Did this disappear in more recent
kernels? If not, can you try the disable_msi and disable_msix module
parameters if they help in your case?

Regards,
Carl-Daniel
-- 
http://www.hailfinger.org/
