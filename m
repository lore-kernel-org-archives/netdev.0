From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH][MCAST]Clear MAF_GSQUERY flag when process MLDv1 general query messages.
Date: Mon, 7 Nov 2005 09:25:20 -0500
Message-ID: <20051107142517.GA13797@tuxdriver.com>
References: <436F610E.8010400@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964827AbVKGO0g@vger.kernel.org>
To: Yan Zheng <yanzheng@21cn.com>
Content-Disposition: inline
In-Reply-To: <436F610E.8010400@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 07, 2005 at 10:13:34PM +0800, Yan Zheng wrote:

> MAF_GSQUERY flag may cause problem when MLDv1 compatibility mode expires.  

Could you be more specific about what problem it will cause?

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
