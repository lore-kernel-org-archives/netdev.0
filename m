From: Alex Deucher <alexdeucher@gmail.com>
Subject: Marvell 88W8310 and 88E8050 PCI Express support
Date: Thu, 24 Feb 2005 16:46:34 -0500
Message-ID: <a728f9f905022413465b96acd4@mail.gmail.com>
Reply-To: Alex Deucher <alexdeucher@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've noticed most of the new AMD64 chipsets now include integrated
marvell GigE and wifi chips onboard.  I haven't been able to find much
on the status of linux support for these chips.  Apparently the PCIE
GigE chip only works with sk98lin and not skge:
http://www.ussg.iu.edu/hypermail/linux/kernel/0502.1/0010.html
Does anyone know if support for the chip is being added to skge?  The
88W8310 doesn't seem to be supported at all, at least not that I can
see.  Does anyone know the status of the 88W8310?  Are there any
experimental drivers?  Is Marvell friendly to opensource?  Are the
databooks available?

Thanks,

Alex

PS, please CC: me as I'm not subscribed.
