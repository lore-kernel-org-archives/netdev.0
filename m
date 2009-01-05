From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH -net-next 1/4] firmware: convert e100
	driver to request_firmware()
Date: Sun, 4 Jan 2009 18:20:24 -0800
Message-ID: <9929d2390901041820h4cf51e2h3612108c516b6869@mail.gmail.com>
References: <1230626401.24796.22.camel@jaswinder.satnam>
	<9929d2390812301433pae01ea4g5bfdef6d4d4c7a9c@mail.gmail.com>
	<20090104.160611.252248503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, jaswinder@infradead.org
To: "David Miller" <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090104.160611.252248503.davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, Jan 4, 2009 at 4:06 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
> Date: Tue, 30 Dec 2008 14:33:36 -0800
>
>> Please hold off on committing, until we have had ample time to do some
>> regression testing.  While this patch may have been in linux-next,
>> this is the first we have seen of it.
>>
>> I am concerned that IPMI traffic will be adversely affected by this patch.
>
> Status please?
> --
>

The only testing left to do is to make sure that ICH devices still
work and to make sure the IPMI traffic is not affected by this patch.
All other testing looks good.  I am sorry that I have been slow to
give status, the holiday's have put a strain on available resources.

-- 
Cheers,
Jeff

------------------------------------------------------------------------------
