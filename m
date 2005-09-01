From: amine <amine@anevia.com>
Subject: Linux multicast support
Date: Thu, 1 Sep 2005 17:05:47 +0200
Message-ID: <200509011705.47623.amine@anevia.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 Hi,
 I have a question about Multicast in Linux IP stack. I need to know why are 
 loking  the " dev->xmit_lock"   when mading change in  device multicast list?
 Is it required to suppress parallel execution of that handler and 
 set_multicast_list?
 Thank in advance

-- 
EL HEDADI Amine
R&D
phone : 
Email : amine@anevia.com
