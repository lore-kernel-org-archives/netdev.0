From: Laurentiu Gosu <laurentiu.gosu@gmail.com>
Subject: Issues booting 4.7.0.1 kernel with i40e driver
Date: Mon, 8 Aug 2016 11:19:38 +0300
Message-ID: <CABddM==7fFywfyiZS_f0RAgbOeUMNxSp+5-1ieUsTRDAe4jhgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3025677333651973871=="
Cc: netdev@vger.kernel.org
To: e1000-devel@lists.sourceforge.net
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

--===============3025677333651973871==
Content-Type: multipart/alternative; boundary=001a11408f08d12aec05398b1365

--001a11408f08d12aec05398b1365
Content-Type: text/plain; charset=UTF-8

Hi,
Just for your information:
I installed 4.7.0.1 kernel from here
http://www.ostechnix.com/linux-kernel-4-7-released-install-centos-7-ubuntu-16-04/
 on a CentOS 6.8 DELL R830 server but it did not boot correctly, see
attached the error( a part of it). I then got latest Intel driver (
i40e-1.5.19), hacked it a bit in order to be able to compile it then I
installed it and it worked like a charm. You may want to update the default
driver from kernel.
The Network card that i used was an Intel(R) Ethernet 10G 4P X710/I350 rNDC
and it worked perfectly fine with firmware version 17.0.12 but it did not
work(and I had to apply above steps) with firmware 17.5.11.

Regards,
Laurentiu.

--001a11408f08d12aec05398b1365--


--===============3025677333651973871==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------

--===============3025677333651973871==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3025677333651973871==--
