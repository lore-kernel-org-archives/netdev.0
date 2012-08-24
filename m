From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [PATCH 6/8] csiostor: Chelsio FCoE offload driver submission
 (headers part 1).
Date: Sat, 25 Aug 2012 00:15:35 +0530
Message-ID: <5037CBCF.70506@chelsio.com>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com> <1345760873-12101-7-git-send-email-naresh@chelsio.com> <50367309.3080306@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: "Love, Robert W" <robert.w.love@intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <50367309.3080306@intel.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/23/2012 11:45 PM, Love, Robert W wrote:
> On 8/23/2012 3:27 PM, Naresh Kumar Inna wrote:
>> This patch contains the first set of the header files for csiostor driver.
>>
>> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
>> ---
>>   drivers/scsi/csiostor/csio_defs.h       |  143 ++++++
>>   drivers/scsi/csiostor/csio_fcoe_proto.h |  843 +++++++++++++++++++++++++++++++
> 
> I think most of these protocol definitions can be found in 
> include/scsi/fc/ and possibly incluse/scsi/scsi_transport_fc.h. I think 
> any protocol stuff missing should be added to the common header files.
> 
> Thanks, //Rob--

Hi Rob,

Thanks for reviewing this patch. I will look into how best I can re-use
the headers in include/scsi/fc and get back if I have questions.

Regards,
Naresh.



> To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

