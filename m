From: Phil Oester <kernel@linuxace.com>
Subject: Re: udp_poll breaks vpnc
Date: Wed, 15 Dec 2004 13:19:53 -0800
Message-ID: <20041215211953.GA17945@linuxace.com>
References: <20041215131342.21768388@lembas.zaitcev.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, shemminger@osdl.org,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pete Zaitcev <zaitcev@redhat.com>
Content-Disposition: inline
In-Reply-To: <20041215131342.21768388@lembas.zaitcev.lan>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Dec 15, 2004 at 01:13:42PM -0800, Pete Zaitcev wrote:
> Hi, Guys:
> 
> I found that the attached patch breaks VPNC. By looking at strace, it never
> gets any poll events about arriving encrypted data. It may be a bug in VPNC,
> but this is a rather old binary which I used even on 2.4...

This was fixed post-rc3.

Phil
