From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.45
Date: Thu, 31 Oct 2002 18:17:08 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021031.181708.102783497.davem@redhat.com>
References: <200211010219.gA12JMn11699@eng2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, ajtuomin@tml.hut.fi, lpetande@tml.hut.fi,
   jagana@us.ibm.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: krkumar@us.ibm.com
In-Reply-To: <200211010219.gA12JMn11699@eng2.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Why isn't the home agent code being done in userspace?  That is
where it belongs.  It's huge.
