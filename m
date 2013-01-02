From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 0/14] qlcnic: Qlogic 83xx CNA adapter driver patches
Date: Wed, 02 Jan 2013 02:44:56 -0800 (PST)
Message-ID: <20130102.024456.1635017592445135759.davem@davemloft.net>
References: <1357046430-31437-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134Ab3ABKo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 05:44:57 -0500
In-Reply-To: <1357046430-31437-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Tue,  1 Jan 2013 08:20:16 -0500

> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> Patches 1-2 refactors the existing 82xx driver
> 
> 0001-qlcnic-change-driver-hardware-interface-mechanism.patch
> 0002-qlcnic-macros-for-common-register-access.patch
> 
> Patches 3-14 add logical features of 83xx adpater
> 
> 0003-qlcnic-83xx-memory-map-and-HW-access-routines.patch
> 0004-qlcnic-83xx-data-path-routines.patch
> 0005-qlcnic-83xx-base-driver.patch
> 0006-qlcnic-83xx-sysfs-routines.patch
> 0007-qlcnic-83xx-adpater-flash-interface-routines.patch
> 0008-qlcnic-83xx-CNA-inter-driver-communication-mechanism.patch
> 0009-qlcnic-flash-template-based-firmware-reset-recovery.patch
> 0010-qlcnic-enable-83xx-virtual-NIC-mode.patch
> 0011-qlcnic-83xx-register-dump-routines.patch
> 0012-qlcnic-83xx-ethtool-interface-routines.patch
> 0013-qlcnic-remove-unused-definitions-from-header-file.patch
> 0014-qlcnic-update-driver-version.patch
> 
> Please apply to net-next.

Series applied, thanks.
