From: maximilian attems <janitor@sternwelten.at>
Subject: Re: [PATCH] don't allow / in class device names
Date: Mon, 16 Feb 2004 23:43:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040216224343.GF1890@mail.sternwelten.at>
References: <20040213102755.27cf4fcd.shemminger@osdl.org> <20040213203448.GB14048@kroah.com> <20040213124555.00cbf3d7@dell_ss3.pdx.osdl.net> <20040213205936.GE14048@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, Tommi Virtanen <tv@tv.debian.net>,
        Leann Ogasawara <ogasawara@osdl.org>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <20040213205936.GE14048@kroah.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 13 Feb 2004, Greg KH wrote:

> But isn't a '/' character a valid character for a file or directory
> name?  :) 

don't know which posix doc ulrich drepper is quoting,
but it doesn't seem so:
http://marc.theaimsgroup.com/?l=linux-kernel&m=107669877325770&w=2

regards
maks
