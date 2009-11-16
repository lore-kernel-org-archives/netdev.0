From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: mac address fix
Date: Sun, 15 Nov 2009 21:17:12 -0800 (PST)
Message-ID: <20091115.211712.254217052.davem@davemloft.net>
References: <1258187485-11549-1-git-send-email-stas@lvk.cs.msu.su>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aabdulla@nvidia.com, yinghai@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stas@lvk.cs.msu.su
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751769AbZKPFQ6@vger.kernel.org>
In-Reply-To: <1258187485-11549-1-git-send-email-stas@lvk.cs.msu.su>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Stanislav O\. Bezzubtsev" <stas@lvk.cs.msu.su>
Date: Sat, 14 Nov 2009 11:31:25 +0300

> Use the existing random_ether_addr() to generate random MAC
> instead of doing it by-hand.
> 
> Signed-off-by: Stanislav O. Bezzubtsev <stas@lvk.cs.msu.su>

Applied, thank you.
