From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH 11/31] Constify struct file_operations for 2.6.32 v1
Date: Mon, 07 Dec 2009 18:35:07 +0100
Message-ID: <4B1D3CCB.5000607@gmail.com>
References: <4B198670.2000406@gmail.com> <4B198C43.50205@gmail.com> <4B19A333.5080103@gmail.com> <20091205000942.GA8224@suse.de> <4B19CA6F.4090700@gmail.com> <20091205041507.GA24885@suse.de> <4B1B0D40.3040209@gmail.com> <20091206172526.GA17480@suse.de> <4B1C500E.5040406@gmail.com> <20091207151156.GA27574@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lenb@kernel.org, astarikovskiy@suse.de, mchehab@infradead.org,
	linville@tuxdriver.com, miklos@szeredi.hu, davem@davemloft.net,
	rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com,
	avi@redhat.com, mtosatti@redhat.com, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935548AbZLGRdy@vger.kernel.org>
In-Reply-To: <20091207151156.GA27574@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> From: Emese Revfy <re.emese@gmail.com>
>>
>> Constify struct file_operations with some exceptions.
> 
> Now please break this patch (and your others) out into "one subsystem at
> a time" type thing so it will have a chance at being applied.

Shall i split them up per subsystem and structure type or
only per subsystem (that is, include all affected structures
in the given subsystem)?
--
Emese
