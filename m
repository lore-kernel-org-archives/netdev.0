From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] qlcnic: refactor 82xx adapter driver
Date: Wed, 28 Nov 2012 11:10:59 -0500 (EST)
Message-ID: <20121128.111059.948286425181573384.davem@davemloft.net>
References: <1354113271-23850-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab2K1QLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:11:01 -0500
In-Reply-To: <1354113271-23850-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Wed, 28 Nov 2012 09:34:25 -0500

> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> Refactor 82xx adapter driver to create new files for:
> Data path routines.
> Sysfs interface routines.
> Hardware register dump utility.
> 
> We are refactoring the driver code to add support for a new adapter.
> Existing 82xx driver code has coding style issues.
> Each physical refactoring patch is followed by a seperate patch
> to fix the style issues in the newly created file.
> 
> Patches in the series are listed below.
> 0001-qlcnic-create-file-qlcnic_io.c-for-datapath-routines.patch
> 0002-qlcnic-fix-coding-style-issues-in-qlcnic_io.c.patch
> 0003-qlcnic-create-file-qlcnic_sysfs.c-for-sysfs-routines.patch
> 0004-qlcnic-fix-style-issues-in-qlcnic_sysfs.c-file.patch
> 0005-qlcnic-create-file-qlcnic_minidump.c-for-dump-utilit.patch
> 0006-qlcnic-fix-coding-style-issues-in-qlcnic_minidump.c.patch
> 
> Please apply to net-next.

All applied, thanks.
