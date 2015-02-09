From: Andrej Manduch <amanduch@gmail.com>
Subject: Re: [PATCH] net:ethernet:intel:Remove outdated fix me comment in
 the function,gb_acquire_swfw_sync_i210
Date: Mon, 09 Feb 2015 02:17:14 -0500
Message-ID: <54D85EFA.3020501@gmail.com>
References: <1423372910-29183-1-git-send-email-xerofoify@gmail.com> <1423444889.2589.165.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423444889.2589.165.camel@jtkirshe-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Can you please leave full patch with git diff when you're replying to
Nicks e-mails? Nick is banned in *@vger.kernel.org so we cannot see his
patches and rest of the world is seeing only replyies to his e-mail. And
it's really hard to test anything when we don't see changes.

On 02/08/2015 08:21 PM, Jeff Kirsher wrote:
> On Sun, 2015-02-08 at 00:21 -0500, Nicholas Krause wrote:
>> Removes the outdated fix me comment in the
>> function,gb_acquire_swfw_sync_i210
>> for setting the variables, i and timeout to the intended correct
>> values for
>> the function,gb_acquire_swfw_sync_i210 to function correctly. This
>> comment is
>> no longer due to these values having been no changed in the last few
>> years and
>> no known issues have been found for these variables being set to their
>> current
>> values. Due to this the comment can now be removed as the values set
>> for these
>> variables are known to be correct after years of no known issues or
>> bugs related
>> to their current values.
>>
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>> ---
>>  drivers/net/ethernet/intel/igb/e1000_i210.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Thank Nick, I will add your patch to my queue.
> 

-- 
Kind regards,
b.
