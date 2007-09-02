From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: That whole "Linux stealing our code" thing
Date: Sun, 2 Sep 2007 03:06:57 +0100
Message-ID: <20070902020657.GP21089@ftp.linux.org.uk>
References: <200709010140.l811eq9H005896@cvs.openbsd.org> <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com> <46D99FB7.6030505@garzik.org> <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com> <20070901205457.GK9260@stusta.de> <20070901215225.GM9260@stusta.de> <3A831845-B630-42AD-B52F-DC9EA2060BAE@dixongroup.net> <46DA1315.9060002@garzik.org> <f34ca13c0709011839yb32f419s20c259cbaabdd132@mail.gmail.com> <46DA18C2.1000104@ncsu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Constantine A. Murenin" <mureninc@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Jason Dixon <jason@dixongroup.net>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, jirislaby@gmail.com,
	alan@lxorguk.ukuu.org.uk
To: Casey Dahlin <cjdahlin@ncsu.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933994AbXIBCHV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46DA18C2.1000104@ncsu.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 01, 2007 at 09:58:26PM -0400, Casey Dahlin wrote:
> Suppose you saw some other variant of *nix that had some code you wanted 
> to use, but there was a gaping security hole in it. Wouldn't you patch 
> it before you incorporated it? and would it be your fault if this fix 
> made the code not work with the original?
> 
> We took the code and fixed a gaping security vulnerability that appeared 
> within the opening comment. We DO care who does what with our code, and 
> we fully intend to cover our balls.

Who's "we" and would you mind showing your contributions to the tree?
git doesn't seem to find them in 2.5.0-to-current for some reason...
