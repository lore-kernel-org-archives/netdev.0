From: Paul Gortmaker <p_gortmaker@yahoo.com>
Subject: Re: Ax88190 specs (was 8390 specs)
Date: Sun, 19 Dec 2004 02:37:33 -0500
Message-ID: <41C52FBD.5080705@yahoo.com>
References: <41C37CAA.3030608@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: marcelo.tosatti@cyclades.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Xose Vazquez Perez <xose@wanadoo.es>
In-Reply-To: <41C37CAA.3030608@wanadoo.es>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I sent Marcelo the relevant pages a while ago.  If anyone wants
to compare the crap-o AX to the NS part, the NS documents in full
are at:

http://www.national.com/ds.cgi/DP/DP8390D.pdf

The AT/LANTIC is the more modern version - the one that could do
both NE2000 and wd8013 on pretty much one chip.  I believe the
83905 datasheet contains all the core 8390 info in it and may
have been more up to date:

http://www.national.com/ds.cgi/DP/DP83905.pdf

Paul.



Xose Vazquez Perez wrote:

> Tosatti wrote:
>
>> I'm having a problem with a Linksys EtherFast card (driven by 
>> axnet_cs), where the interrupt status reports ENISR_RX_ERR (receive 
>> error) under load.
>>
>> I would like to know more details about this status bit, what can 
>> causes it to be turned on, etc.
>>
>> Do you know where I can find 8390 specs?
>>
>> 8390.c mentions
>> Sources:
>> The National Semiconductor LAN Databook, and the 3Com 3c503 databook.
>>
>> But I can't find those available in either Google search or the 
>> National Semiconductor website.
>>
>> Any information or pointers are welcome, thanks!
>
>
>
> Maybe these
>
>   http://www.asix.com.tw/download/Ax88190.pdf
>   http://www.asix.com.tw/download/Ax88190a.pdf
>
> can help you. More docs at -> 
> http://www.asix.com.tw/download_datasheet.htm
>
> regards,
