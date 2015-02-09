From: nick <xerofoify@gmail.com>
Subject: Re: [PATCH] net:ethernet:intel:Remove outdated fix me
 comment in the function, gb_acquire_swfw_sync_i210
Date: Sun, 08 Feb 2015 20:28:24 -0500
Message-ID: <54D80D38.3080708@gmail.com>
References: <1423372910-29183-1-git-send-email-xerofoify@gmail.com>	
	<1423444889.2589.165.camel@jtkirshe-mobl>
	<1423445167.2589.167.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1423445167.2589.167.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



On 2015-02-08 08:26 PM, Jeff Kirsher wrote:
> On Sun, 2015-02-08 at 17:21 -0800, Jeff Kirsher wrote:
>> On Sun, 2015-02-08 at 00:21 -0500, Nicholas Krause wrote:
>>> Removes the outdated fix me comment in the
>>> function,gb_acquire_swfw_sync_i210
>>> for setting the variables, i and timeout to the intended correct
>>> values for
>>> the function,gb_acquire_swfw_sync_i210 to function correctly. This
>>> comment is
>>> no longer due to these values having been no changed in the last few
>>> years and
>>> no known issues have been found for these variables being set to their
>>> current
>>> values. Due to this the comment can now be removed as the values set
>>> for these
>>> variables are known to be correct after years of no known issues or
>>> bugs related
>>> to their current values.
>>>
>>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>>> ---
>>>  drivers/net/ethernet/intel/igb/e1000_i210.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> Thank Nick, I will add your patch to my queue.
> 
> Oh and the title should be "igb: Remove outdated ...", not
> "net:ethernet:intel: Remove ..."
> 
Jeff,
Sorry about the title. Good to known for next time. Should I resend or 
will you fix the title for me?
Cheers,
Nick

------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
