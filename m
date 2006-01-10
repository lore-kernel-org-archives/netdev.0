From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2 2.6.15-060110
Date: Tue, 10 Jan 2006 11:25:34 -0800
Message-ID: <20060110112534.5cf7e43b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update to iproute2 is available.  Most of the changes were to repair the
things that broke with the introduction of the batch mode to the ip command.
	http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.15-060110.tar.gz

For information see:
	http://linux-net.osdl.org/index.php/Iproute2

Recent changes
Masahide NAKAMURA 
	Add ip link ntable

Stephen Hemminger
        Update headers to santized kernel 2.6.15
        Fix ipv6 priority option in u32
	Add corrupt feature for netem

Jamal Hadi Salim
	Add ifb documention

Patrick McHardy
        Add back ip command aliases


-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
