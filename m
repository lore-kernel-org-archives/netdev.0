From: Joe Jin <joe.jin@oracle.com>
Subject: Re: 82571EB: Detected Hardware Unit Hang
Date: Thu, 12 Jul 2012 11:12:41 +0800
Message-ID: <4FFE40A9.4060807@oracle.com>
References: <4FFA9B96.6040901@oracle.com> <4FFBDC50.5090800@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EE41F@ORSMSX102.amr.corp.intel.com>
	<4FFCCA22.8060006@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EEC8B@ORSMSX102.amr.corp.intel.com>
	<4FFCDA6C.8020708@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EED74@ORSMSX102.amr.corp.intel.com>
	<4FFCF314.6020400@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EEDD7@ORSMSX102.amr.corp.intel.com>
	<4FFD0908.6080506@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EF8AD@ORSMSX102.amr.corp.intel.com>
	<4FFE3505.8060407@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F018D@ORSMSX102.amr.corp.intel.com>
	<4FFE3D27.7020500@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F01BE@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040203030107060606040603"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA891274F01BE@ORSMSX102.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040203030107060606040603
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 07/12/12 11:07, Dave, Tushar N wrote:
>> -----Original Message-----
>> From: Joe Jin [mailto:joe.jin@oracle.com]
>> Sent: Wednesday, July 11, 2012 7:58 PM
>> To: Dave, Tushar N
>> Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org
>> Subject: Re: 82571EB: Detected Hardware Unit Hang
>>
>> On 07/12/12 10:52, Dave, Tushar N wrote:
>>> What is the exact error messages in BIOS log?
>>
>> Error message from BIOS event log:
>> 07/12/12 05:54:00
>>    PCI Express Non-Fatal Error
>>
>> Thanks,
>> Joe
> 
> Thanks.  Well, I will check with team tomorrow if this  (max payload size) can be treated as solution to this issue. 
> We can know more about what exact non-fatal error occurred if we capture bus trace.
> We should check the eeprom on this device to make sure they are up-to-date.
> Send me the full eeprom dump in a file and I will confirm with team that it is up-to-date.
> Thanks for your work.
> 

Hi Tushar,

Please find eeprom from attachment.

Thanks a lot of your help,
Joe

--------------040203030107060606040603
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
--------------040203030107060606040603
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--------------040203030107060606040603--
