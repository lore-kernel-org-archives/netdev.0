From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] Make rt_cache_stat use kmalloc_percpu
Date: Fri, 20 Dec 2002 23:29:09 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021220.232909.88324816.davem@redhat.com>
References: <20021216192212.C26076@in.ibm.com>
	<20021220.230528.106417474.davem@redhat.com>
	<3E0418EC.B55941EE@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kiran@in.ibm.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   dipankar@in.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@digeo.com
In-Reply-To: <3E0418EC.B55941EE@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andrew Morton <akpm@digeo.com>
   Date: Fri, 20 Dec 2002 23:31:56 -0800

   "David S. Miller" wrote:
   > I can't consider this seriously until the kmalloc_percpu stuff
   > actually makes it into Linus's tree.  Last I checked, Andrew had
   > a lot of legitimate gripes with the ideas.
   
   Kiran's latest (vastly simpler) version looks fine to my eye.
   
Ok, so once that is in, he can feel free to resubmit the
rt_cache_state patch.
