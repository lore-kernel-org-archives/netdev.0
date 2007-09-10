From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [2.6 patch] make sctp_addto_param() static
Date: Mon, 10 Sep 2007 09:40:21 -0400
Message-ID: <46E54945.30806@hp.com>
References: <20070909202550.GX3563@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>, sri@us.ibm.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760134AbXIJNlP@vger.kernel.org>
In-Reply-To: <20070909202550.GX3563@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> sctp_addto_param() can become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Ack

-vlad
