From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 5/9] r8169:update rtl8168fb ephy parameter
Date: Wed, 10 Dec 2014 00:48:58 +0100
Message-ID: <20141209234858.GB22285@electric-eye.fr.zoreil.com>
References: <1418143563-7652-1-git-send-email-hau@realtek.com>
 <1418143563-7652-6-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chunhao Lin <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418143563-7652-6-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chunhao Lin <hau@realtek.com> :
[rtl_hw_start_8168f_1 and rtl_hw_start_8168f_2 changes]

Different ephy_info data, same code. You may consider factoring it out.

-- 
Ueimor
