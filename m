From: "Nicholas Dearham" <Dearhamn@nu.ac.za>
Subject: unresolved symbol main_table and local_table
Date: Thu, 14 Nov 2002 09:42:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <sdd3700b.016@smtp.nu.ac.za>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there,

I'm new to writing Linux kernel modules for an Ipaq. When I compile my
module everything is fine, but when I install it onto the Ipaq I get
unresolved symbol main_table and unresolved symbol local_table. How do I
overcome these. The Linux code seems to already define these pointers,
so I don't need anything extra in my code (at least I think!). I'm using
Linux 2.4.28-rmk3 for both my Ipaq and my i686. I, however, am using the
"Familiar" distribution for the Ipaq and a 
Toolchain cross-compiler (arm-Linux-gcc) to build the modules required.
I read on "The Linux-kernel mailing list FAQ" section 8, that one must
use -02 compiler extension to ensure the code gets inline'd and I'm
doing this, but still get the error!

Any help will be greatly appreciated,
Thanks,

Nic D. 
