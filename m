From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [BK] XFRM Clean-Up xfrm_lookup()
Date: Sat, 20 Mar 2004 13:51:51 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040320.135151.114415274.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Please pull the following changesets from <http://bk.skbuff.net:10772>.
(Sorry I don't know how to send changesets in e-mail.)

Thanks.

ChangeSet@1.1819, 2004-03-20 12:35:40+09:00, yoshfuji@linux-ipv6.org
  [XFRM] remove unused argument for (*find_bundle)().

ChangeSet@1.1818, 2004-03-20 12:34:37+09:00, yoshfuji@linux-ipv6.org
  [XFRM] remove duplicated lines; fl->fl4_{src,dst} is already filled in xfrm_lookup().

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
