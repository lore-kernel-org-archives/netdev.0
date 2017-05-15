From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/3] Fix ERROR: Macros with complex values should be
 enclosed in parentheses
Date: Mon, 15 May 2017 02:25:31 +0200
Message-ID: <20170515002531.GG14058@lunn.ch>
References: <20170514175130.18664-1-macfij7@wp.pl>
 <20170514175130.18664-2-macfij7@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@redhat.com, jasonwang@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Maciek Fijalkowski <macfij7@wp.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170514175130.18664-2-macfij7@wp.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 14, 2017 at 07:51:29PM +0200, Maciek Fijalkowski wrote:
> From: Maciej Fijalkowski <macfij7@wp.pl>

Hi Maciek

Please include some commit message, even if it is just the checkpatch
error you are fixing.

Please include the subsystem/driver you are patch in the subject line.
Also, your subject of Fix ERROR: makes it sound a lot worse than it
is. 

net: virtio: Fix checkpatch error Complex macros should use ()

Also, you should at least compile test your change. It is clearly
wrong, as shown by 0-day.

       Andrew
