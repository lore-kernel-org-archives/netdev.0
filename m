From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 4/6] mlxsw: core: Implement temperature hwmon
 interface
Date: Fri, 27 Nov 2015 13:05:09 +0100
Message-ID: <20151127120509.GA2177@nanopsycho.orion>
References: <1448535813-14882-5-git-send-email-jiri@resnulli.us>
 <201511271941.qRI1C6Tf%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37521 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753447AbbK0MFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 07:05:12 -0500
Received: by wmww144 with SMTP id w144so55745268wmw.0
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 04:05:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <201511271941.qRI1C6Tf%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Nov 27, 2015 at 12:55:37PM CET, lkp@intel.com wrote:
>Hi Jiri,
>
>[auto build test ERROR on: net-next/master]
>[also build test ERROR on: v4.4-rc2 next-20151127]
>
>url:    https://github.com/0day-ci/linux/commits/Jiri-Pirko/mlxsw-driver-update/20151126-190702
>config: x86_64-randconfig-s2-11271831 (attached as .config)
>reproduce:
>        # save the attached .config to linux build tree
>        make ARCH=x86_64 
>
>All errors (new ones prefixed by >>):
>
>   drivers/built-in.o: In function `mlxsw_hwmon_init':
>>> (.text+0x1d18c2): undefined reference to `devm_hwmon_device_register_with_groups'

I'm on this. Will send v2 soon. Thanks.

>
>---
>0-DAY kernel test infrastructure                Open Source Technology Center
>https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
