From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] iwl-debugfs.c: remove unnecessary casts of void *
Date: Mon, 11 Jan 2010 09:51:50 +0800
Message-ID: <1263174710.15653.242.camel@debian>
References: <201001081614.10343.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"Chatre, Reinette" <reinette.chatre@intel.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753349Ab0AKBvy@vger.kernel.org>
In-Reply-To: <201001081614.10343.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-01-09 at 07:14 +0800, H Hartley Sweeten wrote:
> iwl-debugfs.c: remove unnecessary casts of void *
> 
> void pointers do not need to be cast to other pointer types.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Cc: Zhu Yi <yi.zhu@intel.com>
> Cc: Reinette Chatre <reinette.chatre@intel.com>
> Cc: John W. Linville <linville@tuxdriver.com>

Acked-by: Zhu Yi <yi.zhu@intel.com>

Thanks,
-yi
