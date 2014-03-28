From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net/mac80211: Use RCU_INIT_POINTER(x, NULL) in util.c
Date: Fri, 28 Mar 2014 09:36:41 +0100
Message-ID: <1395995801.4175.4.camel@jlt4.sipsolutions.net>
References: <1395602503-14958-1-git-send-email-monamagarwal123@gmail.com>
	 (sfid-20140323_202244_669399_5CEA350C)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Monam Agarwal <monamagarwal123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395602503-14958-1-git-send-email-monamagarwal123@gmail.com> (sfid-20140323_202244_669399_5CEA350C)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Applied, but I rewrote the commit log and squashed the mac80211 patches
into one.

johannes
