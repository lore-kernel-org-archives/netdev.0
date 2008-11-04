From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: time for TCP ECN defaulting to on?
Date: Tue, 4 Nov 2008 14:32:25 +0000
Message-ID: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Linux Kernel" <linux-kernel@vger.kernel.org>,
	"Linux Netdev" <netdev@vger.kernel.org>,
	"Linux Networking" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Is it time to enable TCP ECN per default and get the benefits, since
router support has been around and known-about for really considerable
time?

Perhaps it should be a question of enabling it, and educating people
to disable it if they run into issues, since we'll probably be in the
same situation in 5 years...and it'll be some time before these
kernels hit devices/servers anyway.

Daniel
-- 
Daniel J Blueman
