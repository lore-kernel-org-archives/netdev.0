From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix to avoid overriding TCP/UDP with a new protocol of
 same type.
Date: Wed, 19 Feb 2003 16:17:01 -0800 (PST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030219.161701.122322786.davem@redhat.com>
References: <Pine.LNX.4.44.0302191603540.1590-100000@dyn9-47-18-140.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: sri@us.ibm.com
In-Reply-To: <Pine.LNX.4.44.0302191603540.1590-100000@dyn9-47-18-140.beaverton.ibm.com>
List-Id: netdev.vger.kernel.org

   From: Sridhar Samudrala <sri@us.ibm.com>
   Date: Wed, 19 Feb 2003 16:14:48 -0800 (PST)

   I think i found a bug in inet_register_protosw() which results in a
   behavior that is not expected.
   
Thanks Sridhar, this looks like a good fix.
