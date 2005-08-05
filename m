From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: atheros driver - desc
Date: Fri, 05 Aug 2005 14:39:53 -0400
Message-ID: <42F3B279.2010200@pobox.com>
References: <20050805180709.GD3067@ntjohd.mshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-mentors@selenic.com, netdev@vger.kernel.org
Return-path: <kernel-mentors-bounces@selenic.com>
To: Mateusz Berezecki <mateuszb@gmail.com>
In-Reply-To: <20050805180709.GD3067@ntjohd.mshome.net>
List-Unsubscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://www.selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

Mateusz Berezecki wrote:
> And regarding that ieee80211 API, I would be very excited if
> anyone could explain the general overview of how new wireless
> API works. I read the source but sometimes a quick answer from
> experienced kernel coder would do more good. 


There is no document describing the API AFAIK.

The best thing to do is read over the ipw2[12]00 drivers.

	Jeff
