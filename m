From: Jes Sorensen <jes@wildopensource.com>
Subject: Re: [PATCH] rrunner: fix section references
Date: 28 Feb 2005 02:51:01 -0500
Message-ID: <yq0wtst5di2.fsf@jaguar.mkp.net>
References: <20050227221425.38a12015.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik <jgarzik@pobox.com>,
        torvalds <torvalds@osdl.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20050227221425.38a12015.rddunlap@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Randy" == Randy Dunlap <rddunlap@osdl.org> writes:

Randy> rrunner: references __initdata in a __devinit function; data
Randy> should be __devinitdata;

Randy> Error: ./drivers/net/rrunner.o .text refers to 00000000000002b2
Randy> R_X86_64_32S .init.data

Randy> Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

Looks good!

Signed-off-by: Jes Sorensen <jes@wildopensource.com>

Jes
