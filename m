From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP-Protection is really a pain...
Date: Thu, 3 Feb 2005 12:15:03 -0800
Message-ID: <20050203121503.4f122779@dxpl.pdx.osdl.net>
References: <4201A382.1020208@rapidforum.com>
	<20050202205437.571a702b@localhost.localdomain>
	<4201B4EA.2030101@rapidforum.com>
	<20050203113335.46396c11@dxpl.pdx.osdl.net>
	<42028278.7040008@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
In-Reply-To: <42028278.7040008@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 03 Feb 2005 20:58:48 +0100
Christian Schmid <webmaster@rapidforum.com> wrote:

E1000 support TSO. To check if it is enabled do:
	ethtool -k eth0
To turn it off use.
	ethtool -K eth0 tso off

You get the idea..

-- 
Stephen Hemminger	<shemminger@osdl.org>
