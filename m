From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Last night Linus bk - netfilter busted?
Date: Fri, 11 Mar 2005 02:23:34 -0500
Message-ID: <200503110223.34461.dtor_core@ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

My box gets stuck while booting (actually starting ntpd) whith tonight
pull from Linus. It looks like it is spinning in ipt_do_table when I do
SysRq-P. No call trace though.

Anyone else seeing it? Any ideas?

-- 
Dmitry
