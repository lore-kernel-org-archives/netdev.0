From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: atheros driver - desc
Date: Fri, 05 Aug 2005 04:55:31 +0200
Message-ID: <42F2D523.9020702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <kernel-mentors-bounces@selenic.com>
To: kernel-mentors@selenic.com
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

Hi list members,

I just post the code for review for anyone interested.
I would be more than pleased to hear some feedback from you on the code.

Im sending a series of 8 patches splitted and diffed as in 
SubmittingPatches documentation.

The driver is not yet fully working because I didn't finish kernel 
integration yet. Almost all
driver I/O ops are reverse engineered independently of openbsd openhal 
which is missing just too much.


Ok, enough talking. Most of the atheros 5212 hal is now open :)

sending patches...

Mateusz
