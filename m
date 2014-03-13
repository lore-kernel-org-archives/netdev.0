From: Jim Davis <jim.epost@gmail.com>
Subject: randconfig build error with next-20140313,
	in drivers/net/ethernet/intel/i40evf
Date: Thu, 13 Mar 2014 15:22:19 -0700
Message-ID: <CA+r1ZhjUM_JNzFuWQ5EZyb3uJMiNb7thz8Y+sT8NUZVVXuYtOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=bcaec51593e3f8720b04f48462bd
To: broonie <broonie@kernel.org>, linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>, jeffrey.t.kirsher@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--bcaec51593e3f8720b04f48462bd
Content-Type: text/plain; charset=ISO-8859-1

Building with the attached random configuration file,

drivers/net/ethernet/intel/i40evf/built-in.o:(.data+0x320): multiple definition
of `i40e_ptype_lookup'
drivers/net/ethernet/intel/i40e/built-in.o:(.data+0x7a0): first defined here
make[4]: *** [drivers/net/ethernet/intel/built-in.o] Error 1

--bcaec51593e3f8720b04f48462bd
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
--bcaec51593e3f8720b04f48462bd
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--bcaec51593e3f8720b04f48462bd--
