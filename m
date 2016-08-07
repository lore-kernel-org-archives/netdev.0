From: Denis Turischev <denis.turischev@compulab.co.il>
Subject: Re: [Intel-wired-lan] e1000e: PHY cann't be initialized correctly on
 some I218 controllers
Date: Sun, 7 Aug 2016 11:56:09 +0300
Message-ID: <57A6F7A9.1030401@compulab.co.il>
References: <579F407E.9090602@compulab.co.il>
 <1e8f37ec-eda4-eb2d-64d2-e96a7aa71902@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Raanan Avargil <raanan.avargil@intel.com>,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1e8f37ec-eda4-eb2d-64d2-e96a7aa71902@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Raanan,

On 08/04/2016 07:18 PM, Raanan Avargil wrote:
> It is hard to determine what is exactly the problem here and what causes the -3 error, but this is not the place to perform hw reset and retry to init the phy.

I agree that may be this is not the correct place for hw reset, can you advice about another solution?

It works, not only for me, for example it helps here:
http://www.linux.org.ru/forum/linux-hardware/10268216

Another fact that Windows drivers work fine with the same hw.

Denis
