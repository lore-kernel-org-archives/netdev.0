From: "David S. Miller" <davem@redhat.com>
Subject: Re: new networking features
Date: Thu, 08 May 2003 09:44:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030508.094405.55858508.davem@redhat.com>
References: <3EBA9852.4030808@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3EBA9852.4030808@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Independant of whether I'm interested in the changes, please use
ethtool in deference to ioctls.  If you absolutely must use
ioctls, I can't accept the changes without updates to the
compatability layer ioctl translation code of every platform.
